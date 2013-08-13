From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: question about netif_rx
Date: Tue, 13 Aug 2013 08:28:03 +0200
Message-ID: <20130813062803.GA13239@electric-eye.fr.zoreil.com>
References: <alpine.DEB.2.02.1308111151210.2072@localhost6.localdomain6>
 <20130811155640.GA10070@electric-eye.fr.zoreil.com>
 <alpine.DEB.2.02.1308111811440.2072@localhost6.localdomain6>
 <20130813052036.GA11640@electric-eye.fr.zoreil.com>
 <CAJJAcoe+GpRYqHyu1xctRaUnPXf4CP8=PTt=svJzJFtBjfqxrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>, grant.likely@linaro.org,
	rob.herring@calxeda.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJJAcoe+GpRYqHyu1xctRaUnPXf4CP8=PTt=svJzJFtBjfqxrg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Shwatrz <dshwatrz@gmail.com> :
[...]
> what is the current state of checksum offloading support has to do
> with it ? maybe you meant current state of NAPI support ?

netif_receive_skb vs napi_gro_receive choice.

-- 
Ueimor
