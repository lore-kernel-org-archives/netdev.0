From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] VNIC: Adding support for Cavium ThunderX network
 controller
Date: Thu, 30 Oct 2014 19:45:13 -0700
Message-ID: <20141030194513.089d27ec@urahara>
References: <20141030165434.GW20170@rric.localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rrichter@cavium.com>,
	Stefan Assmann <sassmann@redhat.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Robert Richter <rric@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141030165434.GW20170@rric.localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Oct 2014 17:54:34 +0100
Robert Richter <rric@kernel.org> wrote:

> diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
> index 1fa99a301817..80bd3336691e 100644
> --- a/include/linux/pci_ids.h
> +++ b/include/linux/pci_ids.h
> @@ -2324,6 +2324,8 @@
>  #define PCI_DEVICE_ID_ALTIMA_AC9100	0x03ea
>  #define PCI_DEVICE_ID_ALTIMA_AC1003	0x03eb
>  
> +#define PCI_VENDOR_ID_CAVIUM		0x177d

I don't think PCI folks want this updated with every id anymore.
