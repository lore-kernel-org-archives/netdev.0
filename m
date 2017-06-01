From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [PATCH linux-firmware] Mellanox: Add firmware for mlxsw_spectrum
Date: Thu, 1 Jun 2017 08:48:06 +0300
Message-ID: <bdca2970-249f-2124-a4c5-089bae682d46@mellanox.com>
References: <20170529104228.32947-1-yotamg@mellanox.com>
 <20170530192232.GY13400@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <idosch@mellanox.com>, <jiri@mellanox.com>, <eladr@mellanox.com>,
        <arkadis@mellanox.com>, <netdev@vger.kernel.org>,
        <linux-firmware@kernel.org>
To: Kyle McMartin <kyle@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0073.outbound.protection.outlook.com ([104.47.0.73]:36775
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750848AbdFAFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 01:48:15 -0400
In-Reply-To: <20170530192232.GY13400@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2017 10:22 PM, Kyle McMartin wrote:
> On Mon, May 29, 2017 at 01:42:28PM +0300, Yotam Gigi wrote:
>> Add first firmware for the Mellanox Spectrum switch, as a followup to the
>> recently added commit:
>> 6b7421992b8d ("mlxsw: spectrum: Validate firmware revision on init")
>>
>> The version of the firmware release is 13.1420.122
>>
>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>> ---
>>  mlxsw_spectrum-13.1420.122.mfa2 | Bin 0 -> 860424 bytes
>>  1 file changed, 0 insertions(+), 0 deletions(-)
>>  create mode 100644 mlxsw_spectrum-13.1420.122.mfa2
>>
>> diff --git a/mlxsw_spectrum-13.1420.122.mfa2 b/mlxsw_spectrum-13.1420.122.mfa2
>> new file mode 100644
> Can we please put this in a subdirectory if we're going to be adding
> more versions of this in the future?
>
> --Kyle


Ok. Will fix.
Thanks!
