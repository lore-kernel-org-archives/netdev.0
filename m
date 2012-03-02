From: John Crispin <blogic@openwrt.org>
Subject: Re: [PATCH 5/7] lantiq_etop: use dev_set_mac_address() instead of
 ltq_etop_set_mac_address()
Date: Fri, 02 Mar 2012 14:53:17 +0100
Message-ID: <4F50D0CD.1060100@openwrt.org>
References: <1330620747-4047-1-git-send-email-danny.kukawka@bisect.de> <1330620747-4047-6-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>,
	Joe Perches <joe@perches.com>,
	Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330620747-4047-6-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/03/12 17:52, Danny Kukawka wrote:
> Use dev_set_mac_address() instead of ltq_etop_set_mac_address() directly
> to get validation checks for free.
>
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
Acked-by: John Crispin <blogic@openwrt.org>
