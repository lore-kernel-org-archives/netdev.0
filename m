From: Avi Kivity <avi@redhat.com>
Subject: Re: KVM 10/Gb Ethernet PCIe passthrough with Linux/iSCSI and large
 block sizes
Date: Sun, 17 May 2009 22:53:04 +0300
Message-ID: <4A106B20.7000809@redhat.com>
References: <1242361761.21442.276.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kvm-devel <kvm@vger.kernel.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	Linux-netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"H. Peter Anvin" <hpa@zytor.com>, Hannes Reinecke <hare@suse.de>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Christoph Hellwig <hch@lst.de>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Sheng Yang <sheng@linux.intel.com>,
	Leonid Grossman <leonid.grossman@neterion.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1242361761.21442.276.camel@haakon2.linux-iscsi.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicholas A. Bellinger wrote:
> Greetings all,
>
> The first test results for Linux/iSCSI Initiators and targets for large
> block sizes using 10 Gb/sec Ethernet + PCIe device-passthrough into
> Linux/KVM guests have been posted at:
>
> http://linux-iscsi.org/index.php/KVM-LIO-Target
>
> So far, the results have been quite impressive using the Neterion X3100
> series hardware with recent KVM-85 stable code (with Marcelo's patches,
> see the above link) on v2.6.29.2 KVM guests, and using v2.6.30-rc3 KVM
> Hosts.
>   

Thanks for posting this!  Very impressive results.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

