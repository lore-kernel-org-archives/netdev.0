From: "Martin K. Petersen" <martin.petersen@oracle.com>
Subject: Re: [PATCH v2] scsi: bfa: Increase requested firmware version to 3.2.5.1
Date: Thu, 05 Jan 2017 20:48:33 -0500
Message-ID: <yq1o9zlhsb2.fsf@oracle.com>
References: <BLUPR0701MB15724638DA0BB8FB5CB9B3CF9F940@BLUPR0701MB1572.namprd07.prod.outlook.com>
        <20161224044019.13797-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Tim Ehlers <tehlers@gwdg.de>,
        Rasesh Mody <rasesh.mody@cavium.com>,
        Anil Gurumurthy <anil.gurumurthy@qlogic.com>,
        Sudarsana Kalluru <sudarsana.kalluru@qlogic.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37366 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752851AbdAFBtA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 20:49:00 -0500
In-Reply-To: <20161224044019.13797-1-bpoirier@suse.com> (Benjamin Poirier's
        message of "Fri, 23 Dec 2016 20:40:19 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Benjamin" == Benjamin Poirier <bpoirier@suse.com> writes:

Benjamin> bna & bfa firmware version 3.2.5.1 was submitted to
Benjamin> linux-firmware on Feb 17 19:10:20 2015 -0500 in 0ab54ff1dc
Benjamin> ("linux-firmware: Add QLogic BR Series Adapter Firmware").

Benjamin> Increase bfa's requested firmware version. Also increase the
Benjamin> driver version.  I only tested that all of the devices probe
Benjamin> without error.

Applied to 4.10/scsi-fixes.

-- 
Martin K. Petersen	Oracle Linux Engineering
