From: "David S. Miller" <davem@redhat.com>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Thu, 26 Sep 2002 13:46:08 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020926.134608.31605412.davem@redhat.com>
References: <20020926054721.GA6039@samba.org>
	<200209261309.RAA17837@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbp@samba.org, ak@muc.de, netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209261309.RAA17837@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Thu, 26 Sep 2002 17:09:11 +0400 (MSD)

   I do not understand why tcp_push_pending_frames() was not used
   there... maybe, there was some reason not to use it.
   
   Dave, do you not remember this?

I was just trying to be too clever.  That is all.
