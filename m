From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Broadcom 43xx first results
Date: Wed, 07 Dec 2005 20:05:58 -0500
Message-ID: <439786F6.8020709@pobox.com>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de> <20051205191008.GA28433@infradead.org> <20051205203121.48241a08@griffin.suse.cz> <200512071900.27669.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	Christoph Hellwig <hch@infradead.org>,
	Joseph Jezak <josejx@gentoo.org>, mbuesch@freenet.de,
	linux-kernel@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030415AbVLHBGM@vger.kernel.org>
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200512071900.27669.flamingice@sourmilk.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> The softmac code that is still in adm8211 is actually based on an early 
> version of the softmac code that Jouni made for Devicescape. The Devicescape 
> code does much more useful stuff than the code currently in the kernel. Sure, 
> I can and have been porting adm8211 to the new kernel stuff.. but it already 
> works with a much more mature piece of softmac code. I see the use of Intel's 
> 802.11 code as a step backwards.

Then please update the code in the kernel.

	Jeff
