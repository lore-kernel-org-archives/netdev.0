From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 11:34:48 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020906.113448.07697441.davem@redhat.com>
References: <20020906.103717.82432404.davem@redhat.com>
	<E17nNhM-0003PD-00@w-gerrit2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Martin.Bligh@us.ibm.com, hadi@cyberus.ca, tcw@tempest.prismnet.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: gh@us.ibm.com
In-Reply-To: <E17nNhM-0003PD-00@w-gerrit2>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Gerrit Huizenga <gh@us.ibm.com>
   Date: Fri, 06 Sep 2002 11:19:11 -0700
   
   And, honestly, I'm a kernel guy much more than an applications guy, so
   I'll admit that I'm not up to speed on what Tux2 can do with dynamic
   content.

TUX can optimize dynamic content just fine.

   The last I knew was that it could pass it off to another server.

Not true.

   The problem is that performance on Apache sucks
   but people like the features.

Tux's design allows it to be a drop in acceleration method
which does not require you to relinquish Apache's feature set.
