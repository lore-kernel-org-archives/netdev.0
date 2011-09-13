From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.1-rc4: spectacular kernel errors / filesystem crash
Date: Tue, 13 Sep 2011 16:58:12 +0200
Message-ID: <CAL4WiipmRyprf3nU-mgz8zE+n=Cy_Th=MT1JMnO=Qy_993++yw@mail.gmail.com>
References: <alpine.DEB.2.02.1109110511250.8626@p34.internal.lan>
	<CAEuXFEzs1f7n5taYzupux3AtKmRcY4P0m7yjkUQA8aLyS8eujw@mail.gmail.com>
	<1315886706.2556.11.camel@edumazet-laptop>
	<alpine.DEB.2.02.1109130722210.21380@p34.internal.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Alan Piszcz <ap@solarrain.com>,
	NetDEV list <netdev@vger.kernel.org>, xfs@oss.sgi.com,
	linux-kernel@vger.kernel.org
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1109130722210.21380@p34.internal.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/9/13 Justin Piszcz <jpiszcz@lucidpixels.com>:
>

> I found this commit here:
> http://permalink.gmane.org/gmane.linux.kernel.pci/11700
>
> Applied:
> # patch -p1 < ../ed2888e906b56769b4ffabb9c577190438aa68b8.txt patching file
> drivers/pci/probe.c
>
>

Oh, I should have sent the git anchor you can use instead of searching the web ;

git pull https://github.com/torvalds/linux.git
