From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: configure VF parameters from PF domain
Date: Wed, 14 Oct 2009 10:04:02 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755830244C0@orsmsx508.amr.corp.intel.com>
References: <be5d34890910131101w386bb753oc2798176558db3e0@mail.gmail.com>
 <be5d34890910131105g52ab497av2359b1f974af55a4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>
To: Satish Chowdhury <satish.chowdhury@oneconvergence.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55872 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750909AbZJNREl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 13:04:41 -0400
In-Reply-To: <be5d34890910131105g52ab497av2359b1f974af55a4@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is no such tool yet.  Proposals for such a tool are welcome.  The=
re are some discussions going on between myself and a few other enginee=
rs as to how to proceed but nothing beyond that yet.

I agree completely that such a tool is necessary for SR-IOV networking =
to move from expermimental to something actually useful in real world a=
pplications.

- Greg

>-----Original Message-----
>From: netdev-owner@vger.kernel.org=20
>[mailto:netdev-owner@vger.kernel.org] On Behalf Of Satish Chowdhury
>Sent: Tuesday, October 13, 2009 11:06 AM
>To: netdev@vger.kernel.org
>Subject: configure VF parameters from PF domain
>
>Hi,
>
>I am verifying the functionality=A0 of Intel 82576 based NIC card on
>Xen.=A0 VF device is assigned(passthrough) to a VM.
>
>I can configure the MAC, VLAN parameter of VF in the VM domain on the
>VF interface.  But, I want have control over the VF from PF domain.
>i.e I should be able to configure VF MAC, VLAN parameters from PF
>domain.
>
>Is there any tool available ? Else give me pointers how the above can
>be achieved? Is there a way to preconfigure VF parameters before
>assigning VF to VM.
>
>Regards,
>-Satish
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>