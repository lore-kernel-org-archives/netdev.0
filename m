From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: use RTAX_CWND for outgoing connections properly
Date: Wed, 22 Dec 2010 15:27:43 -0800 (PST)
Message-ID: <20101222.152743.28800942.davem@davemloft.net>
References: <alpine.LNX.2.00.1012221059340.16569@pobox.suse.cz>
	<20101222.115721.39176015.davem@davemloft.net>
	<alpine.LNX.2.00.1012230023490.16569@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, vojtech@suse.cz
To: jkosina@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1012230023490.16569@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jkosina@suse.cz>
Date: Thu, 23 Dec 2010 00:26:21 +0100 (CET)

> On Wed, 22 Dec 2010, David Miller wrote:
> 
>> > Besides that, any comments on this, please?
>> 
>> It's in my backlog, patience is a virtue.
> 
> Please just disregard it, it's not needed with newer kernels. Thanks,

Was it indeed fixed by commit 86bcebafc5e7f5?
