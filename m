From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Mon, 16 Sep 2002 14:29:31 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020916.142931.126209536.davem@redhat.com>
References: <20020916.125211.82482173.davem@redhat.com>
	<Pine.LNX.4.44.0209161528140.13850-100000@gp.staff.osogrande.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, tcw@tempest.prismnet.com, netdev@oss.sgi.com,
   pfeather@cs.unm.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, todd-lkml@osogrande.com
In-Reply-To: <Pine.LNX.4.44.0209161528140.13850-100000@gp.staff.osogrande.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: todd-lkml@osogrande.com
   Date: Mon, 16 Sep 2002 15:32:56 -0600 (MDT)
   
   new system calls into the networking code

The system calls would go into the VFS, sys_receivefile is not
networking specific in any way shape or form.

And to answer your question, if I had the time I'd work on it yes.

Right now the answer to "well do you have the time" is no, I am
working on something much more important wrt. Linux networking.  I've
hinted at what this is in previous postings, and if people can't
figure out what it is I'm not going to mention this explicitly :-)
