From: <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next 0/4] be2net: fixes
Date: Mon, 24 Oct 2011 21:49:41 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F642EFEC8162@EXMAIL.ad.emulex.com>
References: <1319460303-25560-1-git-send-email-sathya.perla@emulex.com>
 <20111024.183546.495965585975609045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:27221 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751313Ab1JYEuE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 00:50:04 -0400
In-Reply-To: <20111024.183546.495965585975609045.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Tuesday, October 25, 2011 4:06 AM
>
>From: Sathya Perla <sathya.perla@emulex.com>
>Date: Mon, 24 Oct 2011 18:14:59 +0530
>
>> Pls apply.
>>
>> Sathya Perla (4):
>>   be2net: add vlan/rx-mode/flow-control config to be_setup()
>>   be2net: refactor VF setup/teardown code into be_vf_setup/clear()
>>   be2net: don't create multiple TXQs in BE2
>>   be2net: don't create multiple RX/TX rings in multi channel mode
>
>Applied, but many of your commit messages were poorly formatted (lines
>exceeding 80 columns) and patches #1 and #2 had several trailing
>whitespace errors.
>
>I fixed this all up, but you have to be better than this.
Dave, thanks. Will be careful....
