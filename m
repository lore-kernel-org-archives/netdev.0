From: Satish Chowdhury <satish.chowdhury@oneconvergence.com>
Subject: configure VF parameters from PF domain
Date: Tue, 13 Oct 2009 23:35:41 +0530
Message-ID: <be5d34890910131105g52ab497av2359b1f974af55a4@mail.gmail.com>
References: <be5d34890910131101w386bb753oc2798176558db3e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f180.google.com ([209.85.223.180]:62758 "EHLO
	mail-iw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760831AbZJMSGi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 14:06:38 -0400
Received: by iwn10 with SMTP id 10so2896038iwn.4
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2009 11:06:01 -0700 (PDT)
In-Reply-To: <be5d34890910131101w386bb753oc2798176558db3e0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am verifying the functionality=A0 of Intel 82576 based NIC card on
Xen.=A0 VF device is assigned(passthrough) to a VM.

I can configure the MAC, VLAN parameter of VF in the VM domain on the
VF interface.  But, I want have control over the VF from PF domain.
i.e I should be able to configure VF MAC, VLAN parameters from PF
domain.

Is there any tool available ? Else give me pointers how the above can
be achieved? Is there a way to preconfigure VF parameters before
assigning VF to VM.

Regards,
-Satish
