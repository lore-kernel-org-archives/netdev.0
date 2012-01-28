From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: so many if conditions in _rtl92c_store_pwrIndex_diffrate_offset.
Date: Sat, 28 Jan 2012 01:31:05 -0500
Message-ID: <CAHdPZaMWC6_bGXXJvjbmJDz-JDF7gx8QUTd2e8iW=5+ecTPiSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi wireless folks,

in _rtl92c_store_pwrIndex_diffrate_offset (
drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c), there are lot of
if conditions, checking the register address.
my understanding is that if the register address matches to a
particular rate, we set the txpower level to a particular group. but
it is even possible with the switch or if else if statements,
=A0please correct me if i am wrong.

Thanks,
Dev.
