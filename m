From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 10:37:17 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020906.103717.82432404.davem@redhat.com>
References: <18563262.1031269721@[10.10.2.3]>
	<E17nMs2-0003F6-00@w-gerrit2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Martin.Bligh@us.ibm.com, hadi@cyberus.ca, tcw@tempest.prismnet.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: gh@us.ibm.com
In-Reply-To: <E17nMs2-0003F6-00@w-gerrit2>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Gerrit Huizenga <gh@us.ibm.com>
   Date: Fri, 06 Sep 2002 10:26:04 -0700
   
   One of our goals is to actually take the next generation of the most
   common "large system" web server and get it to scale along the lines
   of Tux or some of the other servers which are more common on the
   small machines.  For some reasons, big corporate customers want lots
   of features that are in a web server like apache and would also like
   the performance on their 8-CPU or 16-CPU machine to not suck at the
   same time.  High ideals, I know, wanting all features *and* performance
   from the same tool...  Next thing you know they'll want reliability
   or some such thing.

Why does Tux keep you from taking advantage of all the
feature of Apache?  Anything Tux doesn't handle in it's
fast path is simple fed up to Apache.
