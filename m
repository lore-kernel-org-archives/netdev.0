From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: 2.6.19-rc6 : Spontaneous reboots, stack overflows - seems to
	implicate xfs, scsi, networking, SMP
Date: Thu, 23 Nov 2006 19:37:00 +0100
Message-ID: <1164307020.3147.3.camel@laptopd505.fenrus.org>
References: <9a8748490611211551v2ebe88fel2bcf25af004c338a@mail.gmail.com>
	 <20061122.201013.112290046.davem@davemloft.net>
	 <20061123070837.GV11034@melbourne.sgi.com>
	 <200611231416.03387.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Chinner <dgc@sgi.com>, David Miller <davem@davemloft.net>,
	jesper.juhl@gmail.com, chatz@melbourne.sgi.com,
	linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
	xfs-masters@oss.sgi.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: Ingo Oeser <netdev@axxeo.de>
In-Reply-To: <200611231416.03387.netdev@axxeo.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-23 at 14:16 +0100, Ingo Oeser wrote:
> Hi there,
> 
> David Chinner schrieb:
> > If the softirqs were run on a different stack, then a lot of these

softirqs DO run on their own stack!


