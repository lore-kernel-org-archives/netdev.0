From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 12:25:25 -0800
Message-ID: <43A07FB5.6040208@candelatech.com>
References: <Pine.LNX.4.58.0512140042280.31720@w-sridhar.beaverton.ibm.com> <9a8748490512141216x7e25ca2cucb675f11f0c9d913@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964937AbVLNUZf@vger.kernel.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
In-Reply-To: <9a8748490512141216x7e25ca2cucb675f11f0c9d913@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Juhl wrote:

> To be a little serious, it sounds like something that could be used to
> cause trouble and something that will lose its usefulness once enough
> people start using it (for valid or invalid reasons), so what's the
> point...

It could easily be a user-configurable option in an application.  If
DOS is a real concern, only let this work for root users...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
