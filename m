From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] connect() return value.
Date: Thu, 15 Aug 2002 14:23:37 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020815.142337.95077599.davem@redhat.com>
References: <20020815032543.GA3083@gandalf.chinesecodefoo.org>
	<20020814.201514.30457132.davem@redhat.com>
	<20020815110210.GA15218@anakin.wychk.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: glee@gnupilgrims.org
In-Reply-To: <20020815110210.GA15218@anakin.wychk.org>
List-Id: netdev.vger.kernel.org

   From: Geoffrey Lee <glee@gnupilgrims.org>
   Date: Thu, 15 Aug 2002 21:02:10 +1000

   On Wed, Aug 14, 2002 at 08:15:14PM -0700, David S. Miller wrote:
   > How extensive are your notes on poll() behavior on TCP
   > sockets? :-)

   Hmm, in which regard?
   
   Is there something specific that you are searching for? :-)

POLLHUP in particular.  I remember we verified that our behavior
matched Solaris but no checks were performed against others.
