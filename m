From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: New commands to configure IOV features
Date: Wed, 19 Sep 2012 19:27:39 -0700
Message-ID: <CAE9FiQX72SE+NSx=P26x3Ta74U0_UHM28n9cwfy6HeK3bPiXeg@mail.gmail.com>
References: <5003DC9B.8000706@broadcom.com>
	<5005BD00.4090106@redhat.com>
	<5005D45D.1040302@genband.com>
	<20120717.141153.46613285253481776.davem@davemloft.net>
	<500978C7.5050004@genband.com>
	<50097FBD.9080202@redhat.com>
	<1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>
	<5009B186.6000806@genband.com>
	<1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
	<5009ECDF.4090305@genband.com>
	<500D59BF.9040006@redhat.com>
	<500D6932.8090306@genband.com>
	<20120723113607.56ce7aaf@nehalam.linuxnetplumber.net>
	<C5551D9AAB213A418B7FD5E4A6F30A070C7D9DCD@ORSMSX106.amr.corp.intel.com>
	<5059A767.2090307@broadcom.com>
	<20120919085306.00006af9@unknown>
	<1348083847.2636.37.camel@bwh-desktop.uk.solarflarecom.com>
	<CAE9FiQXQj_KdWT-mVVsptxiEgGjScgDy_Lp-aXioZ4YAQh1wWQ@mail.gmail.com>
	<1348094773.2636.85.camel@bwh-desktop.uk.solarflarecom.com>
	<CAE9FiQVk-uXgLK6dM8q5-Xsh8LO+c-Dd_cEpu2WzJ6Uzt6ztnA@mail.gmail.com>
	<1348104190.4836.61.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	linux-pci <linux-pci@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1348104190.4836.61.camel@deadeye.wl.decadent.org.uk>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2012 at 6:23 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2012-09-19 at 17:19 -0700, Yinghai Lu wrote:
>> could just stop the device and add it back again?
>
> This is highly disruptive and I think it would be totally unacceptable
> for at least networking devices.

so you want PF network device continue work while enable VF on it?

Yinghai
