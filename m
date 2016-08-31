From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtl_bt: Add firmware and config file for RTL8822BE
Date: Tue, 30 Aug 2016 20:10:43 -0500
Message-ID: <1d0a046a-9d16-2e1d-8a09-122e2b91979c@lwfinger.net>
References: <1472566081-1072-1-git-send-email-Larry.Finger@lwfinger.net>
 <1472568698.25374.9.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        =?UTF-8?B?6ZmG5pyx5Lyf?= <alex_lu@realsil.com.cn>,
        linux-bluetooth@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>, linux-firmware@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33501 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751783AbcHaBKq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 21:10:46 -0400
In-Reply-To: <1472568698.25374.9.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2016 09:51 AM, Ben Hutchings wrote:
> On Tue, 2016-08-30 at 09:08 -0500, Larry Finger wrote:
>> This device is a new model from Realtek. Updates to driver btrtl will
>> soon be submitted to the kernel.
>>
>> These files were provided by the Realtek developer.
>>
>> Signed-off-by: 陆朱伟 <alex_lu@realsil.com.cn>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> Cc: linux-bluetooth@vger.kernel.org
>> ---
>>  WHENCE                     |   3 +++
>>  rtl_bt/rtl8822b_config.bin | Bin 0 -> 32 bytes
>>  rtl_bt/rtl8822b_fw.bin     | Bin 0 -> 51756 bytes
>>  3 files changed, 3 insertions(+)
>>  create mode 100644 rtl_bt/rtl8822b_config.bin
>>  create mode 100644 rtl_bt/rtl8822b_fw.bin
>>
>> diff --git a/WHENCE b/WHENCE
>> index d0bef0d..a9d7c97 100644
>> --- a/WHENCE
>> +++ b/WHENCE
>> @@ -2755,11 +2755,14 @@ File: rtl_bt/rtl8723b_fw.bin
>>  File: rtl_bt/rtl8761a_fw.bin
>>  File: rtl_bt/rtl8812ae_fw.bin
>>  File: rtl_bt/rtl8821a_fw.bin
>> +File: rtl_bt/rtl8822e_fw.bin
>> +File: rtl_bt/rtl8822e_config.bin
> [...]
>
> Should the filenames begin with "rtl822b" or "rtl822e"?

They should start with rtl8822b. V2 will be sent shortly.

Thanks,

Larry
