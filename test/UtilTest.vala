/* Copyright 2021 Sergej Dobryak <sergej.dobryak@gmail.com>
*
* This program is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with this program. If not, see http://www.gnu.org/licenses/.
*/


public void test_util_cut() {
    assert(Soundy.Util.cut_label_if_necessary("abcde_abcde", 10) == "abcde_a...");
    assert(Soundy.Util.cut_label_if_necessary("Jason Derulo & David Guetta feat. Nicki Minaj & Willy William", 30) == "Jason Derulo & David Guetta...");
}

public void test_util_cut_not_needed() {
    assert(Soundy.Util.cut_label_if_necessary("abcde", 10) == "abcde");
    assert(Soundy.Util.cut_label_if_necessary("a", 10) == "a");
    assert(Soundy.Util.cut_label_if_necessary("abcde_abcd", 10) == "abcde_abcd");
}

public int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test_util", test_util_cut);
    Test.add_func("/test_util_cut_not_needed", test_util_cut_not_needed);
    return Test.run();
}
