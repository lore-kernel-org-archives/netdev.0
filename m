From: Stephen Hemminger <shemminger@osdl.org>
Subject: e100 driver startup problem
Date: Tue, 26 Oct 2004 11:58:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026115850.7b981aac@guest-251-240.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, John Ronciak <john.ronciak@intel.com>,
        Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Something changed recently in the e100 driver. On my SuSe 9.1 driver it no
longer automatically brings up the networking on the e100 (it did before).
The change happened in the latest e100 driver that went in after 2.6.9.
I can start network manually and it appears to be an e100 specific problem
because other ethernet card comes okay.
