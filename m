From: Jerry Natowitz <j.natowitz@rcn.com>
Subject: Possible overwrite in tulip driver >= 2.6.4-mm2
Date: Wed, 17 Mar 2004 06:33:01 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4058376D.2060409@rcn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm not experienced in debugging kernels, so all I can do is report that
starting in 2.6.4-mm2, I get debugging information from the tulip driver
that I never saw before.  I've confirmed that tulip_debug *should* be 1,
but the presence of debug messages indicate that it is being over-written.
-- 
	Jerry Natowitz
	j.natowitz@rcn.com
