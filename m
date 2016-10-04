From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] igb: Realign bad indentation
Date: Tue, 4 Oct 2016 19:32:09 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81F9B94C@ORSMSX101.amr.corp.intel.com>
References: <ef9cc22163546101c34fbade622455422549f43c.1474947967.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36228 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752140AbcJDTcM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 15:32:12 -0400
In-Reply-To: <ef9cc22163546101c34fbade622455422549f43c.1474947967.git.joe@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Joe Perches
> Sent: Monday, September 26, 2016 8:46 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: [PATCH] igb: Realign bad indentation
> 
> Statements should start on tabstops.
> 
> Use a single statement and test instead of multiple tests.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/intel/igb/e1000_mac.c | 15 ++++++---------
>  1 file changed, 6 insertions(+), 9 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
