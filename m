From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCHES] 2.4.x net driver updates
Date: Tue, 17 Jun 2003 15:40:37 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.154037.78070671.davem@redhat.com>
References: <20030612194926.GA7653@gtf.org>
	<20030617222750.GE13990@werewolf.able.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamagallon@able.es
In-Reply-To: <20030617222750.GE13990@werewolf.able.es>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "J.A. Magallon" <jamagallon@able.es>
   Date: Wed, 18 Jun 2003 00:27:50 +0200

   Any info about the RX_POLLING (NAPI) option for e1000 ?
   What is that for ?

Software based interrupt mitigation, see:

Documentation/networking/NAPI_HOWTO.txt

and more specifically:

http://www.cyberus.ca/~hadi/usenix-paper.tgz
