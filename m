From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: nf_reject_ipv4: module license 'unspecified' taints kernel
Date: Fri, 10 Oct 2014 09:53:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174C8305@AcuExch.aculab.com>
References: <20141010091904.GD1981@darkstar.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Dave Young' <dyoung@redhat.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141010091904.GD1981@darkstar.nay.redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Young
> With today's linus tree, I got below kmsg:
> [   23.545204] nf_reject_ipv4: module license 'unspecified' taints kernel.
> [   23.551886] Disabling lock debugging due to kernel taint
...

Not 100% related, but why does loading a non-GPL module disable 
lock debugging?
(Is 'lock debugging' actually useful?)

	David
