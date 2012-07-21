From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: Re: [PATCH] b44: add 64 bit stats
Date: Sat, 21 Jul 2012 12:36:21 -0400
Message-ID: <CABF+-6VZcbaMY=BOJcHmBKdeMtJguampx-+==OuTg_279VOYQA@mail.gmail.com>
References: <CABF+-6XaYk8qXnFNXF_+rQ144jyDFgFqDVKsuZv+S_0VZxBAvw@mail.gmail.com>
	<1342337165.3265.10640.camel@edumazet-glaptop>
	<CABF+-6XVCTDZedzcp-gWACYpG9NLmZUdwW2zsXC8WNKWk3dE5w@mail.gmail.com>
	<1342759989.2626.5472.camel@edumazet-glaptop>
	<1342761865.2626.5572.camel@edumazet-glaptop>
	<CABF+-6Ubh6rSYV=L8-QV466XNo5OqCxA+4DRqXGdELhnSPkPZQ@mail.gmail.com>
	<CABF+-6XGO0Qvqd1O-aY28kG1jV=L6eRcupnZpaimTunddPwL2A@mail.gmail.com>
	<1342847376.2626.8162.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1342847376.2626.8162.camel@edumazet-glaptop>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 21, 2012 at 1:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> drivers/net/dummy.c
>> drivers/net/ethernet/neterion/vxge/vxge-main.c
>> drivers/net/loopback.c
>> drivers/net/virtio_net.c
>> net/bridge/br_device.c
>
> Thats right.

I just submitted a patch for these five drivers.  I don't want to mess
with the other two when I don't fully know what I am doing.


Kevin
