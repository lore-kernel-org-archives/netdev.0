From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 26 May 2003 23:32:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030526.233211.54217447.davem@redhat.com>
References: <87adda6uro.fsf@deneb.enyo.de>
	<20030526.002934.132904126.davem@redhat.com>
	<87wuge59w2.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@shell.cyberus.ca, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: fw@deneb.enyo.de
In-Reply-To: <87wuge59w2.fsf@deneb.enyo.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Florian Weimer <fw@deneb.enyo.de>
   Date: Mon, 26 May 2003 11:34:37 +0200
   
   Of course, this will result in vastly decreased functionality (no
   arbitary netmasks, no policy-based routing, code will be fine-tuned
   for typical Internet routing tables), so this proposal definitely
   comes at a price.

As a general purpose operating system, where people DO in fact use
these features quite regularly, we cannot make these kinds of choices
without making it optional and definiteily non-default behavior.
