From: David Miller <davem@davemloft.net>
Subject: Re: AF_BUS socket address family
Date: Fri, 29 Jun 2012 16:18:21 -0700 (PDT)
Message-ID: <20120629.161821.948325645333976311.davem@davemloft.net>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
	<20120629.153656.1141845894730637434.davem@davemloft.net>
	<20120629231236.GA28593@mail.collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vincent.sanders@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120629231236.GA28593@mail.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Date: Sat, 30 Jun 2012 00:12:37 +0100

> I had hoped you would have at least read the opening list where I
> outlined the underlying features which explain why none of the
> existing IPC match the requirements.

I had hoped that you had read the part we told you last time where
we explained why multicast and "reliable delivery" are fundamentally
incompatible attributes.

We are not creating a full address family in the kernel which exists
for one, and only one, specific and difficult user.
