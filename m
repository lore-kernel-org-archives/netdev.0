From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Crash with e100 and ethtool on 2.6.0-test4 latest
Date: Fri, 5 Sep 2003 17:18:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010124F01F@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>,
   "Jeff Garzik" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> #  ethtool -K eth0 rx off
> 
> Unable to handle kernel paging request at virtual address f8875000

Works for me with ethtool 1.8.  What's your ethtool version?  Also, what
rev is the e100 nic (lspci)?

-scott
