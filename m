From: "David S. Miller" <davem@redhat.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Fri, 27 Jun 2003 01:00:59 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030627.010059.68039169.davem@redhat.com>
References: <18330000.1056692768@[10.10.2.4]>
	<20030626.224739.88478624.davem@redhat.com>
	<20030627075914.GO28900@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbligh@aracnet.com, linux-kernel@vger.kernel.org,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: matti.aarnio@zmailer.org
In-Reply-To: <20030627075914.GO28900@mea-ext.zmailer.org>
List-Id: netdev.vger.kernel.org

   From: Matti Aarnio <matti.aarnio@zmailer.org>
   Date: Fri, 27 Jun 2003 10:59:14 +0300

   The problem with "post to the list" is that sometimes things slip
   thru without anybody catching them.

It is not a problem, it is a feature.  What will happen is the
same thing that happens if Linus drops a patch.

It'll get retransmitted if the reporter cares about the
bug.  If he doesn't, the one of two things:

1) the bug actually isn't that important
2) it is important, and someone else will report the bug too

Therefore important issues tend to keep showing up, even if
they are not attended to the first time around.  This repeated
reporting and patch sending may seem like useless work, but this
is not true, it is actually a form of validation.

   I thought you don't need to login to see things in bugzilla ?

That's not the issue.  Asking people who want to help to
read a list or two, isn't much to ask.  Getting them to click
around some web site every day adds to the overhead.
