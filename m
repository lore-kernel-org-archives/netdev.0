From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.12-rc2 0/11] tg3: Add complete support for 5752
Date: Sun, 17 Apr 2005 23:42:31 -0700
Message-ID: <1113806551.6504.11.camel@rh4>
References: <04132005193843.8300@laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>, davem@davemloft.net
In-Reply-To: <04132005193843.8300@laptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

These patches should be applied on top of John Linville's patches posted
a few days ago.

The last 2 patches are MSI patches for 5751 C0 and 5752. They are very
similar to the MSI patches posted a few weeks ago. I've modified the MSI
test patch to display a warning message to ask the user to report the
failure if the MSI test fails. If Jeff still objects to this, then just
skip patch 11 but apply patch 10 which enables MSI on the latest chips.
