From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 1/2] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Tue, 16 May 2017 18:38:18 +0000
Message-ID: <MWHPR12MB1600A3E5F15C07CD88BA3C88C8E60@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <cover.1493678834.git.leedom@chelsio.com>
 <758d0e431c732fe133e7b0e660bde5fc1beccdba.1493678834.git.leedom@chelsio.com>
 <CAKgT0UeuW88AHBX14H8xHteeG7vR0AH3apbjOeEDx_6p46x7tA@mail.gmail.com>
 <20170502165329.GB26406@linux.intel.com>
 <CAKgT0UcxjGCZu_QV-eF7_yWkDBbQpLpdaPqBf1gji8XXM5Cc=w@mail.gmail.com>
 <MWHPR12MB160095DF53CE981C923FE65DC8160@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0UdJ17DGAphuP5Y9co6ky-GBFdq2s-1nqctY_Tz_iz5__g@mail.gmail.com>
 <MWHPR12MB1600E78DD7F530AA9DC2433DC8EA0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0Ucwkp+fi-9HhMbze6t_i15dj4e2WQBp13Coi6MegrDh=w@mail.gmail.com>
 <22c46382-5778-022f-d0bd-74abec9e9c7c@huawei.com>
 <CAKgT0Ufg6uebqj79e1FOHoPpF-GxPYMkp353r3Ok_=nM8wF6qA@mail.gmail.com>
 <MWHPR12MB1600AC957C7E3B0DB4F06D6CC8EE0@MWHPR12MB1600.namprd12.prod.outlook.com>,<a8a0628f-ccf7-932e-7d1e-9ef767295a6c@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "Raj, Ashok" <ashok.raj@intel.com>,
        Bjorn Helgaas <helgaas@kernel.org>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "Arjun V." <arjun@chelsio.com>,
        Asit K Mallick <asit.k.mallick@intel.com>,
        "Patrick J Cramer" <patrick.j.cramer@intel.com>,
        Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
        Bob Shaw <Bob.Shaw@amd.com>, h <l.stach@pengutronix.de>,
        Mark Rutland <mark.rutland@arm.com>,
        Amir Ancel <amira@mellanox.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        "Catalin Marinas" <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        LinuxArm <linuxarm@huawei.com>,
        David Laight <David.Laight@aculab.com>,
        "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        "Robin Murphy" <robin.mu
To: Ding Tianhong <dingtianhong@huawei.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0123.outbound.protection.outlook.com ([104.47.41.123]:14353
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751203AbdEPSiU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 14:38:20 -0400
In-Reply-To: <a8a0628f-ccf7-932e-7d1e-9ef767295a6c@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Ding Tianhong <dingtianhong@huawei.com>
| Sent: Wednesday, May 10, 2017 6:15 PM
|
| Hi Casey:
|
| Will you continue to work on this solution or send a new version patches?

I won't be able to work on this any time soon given several other urgent
issues.  If you've got a desire to pick this up, I'd be happy to help code
review your efforts.

Casey
