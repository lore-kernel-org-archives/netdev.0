From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: updating MIBs/statistics
Date: Tue, 11 Mar 2003 11:56:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030311115612.73821921.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm looking into doing some MIB updates, such as making the
IPv6 stats table be on a per interface basis (per RFC 2465)
and adding a UDP listener table and TCP connection table as
well as some other IPv6 MIB requirements.

Has anyone else tackled this?

Assuming that the patches for this are in Linux style, are
there any issues with doing updates like these?
Like non-technical issues?

Thanks,
--
~Randy
