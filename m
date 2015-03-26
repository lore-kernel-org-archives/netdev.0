From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH ethtool 0/5] RSS improvements + new speeds
Date: Thu, 26 Mar 2015 11:56:33 +0200
Message-ID: <CAPcc5PjD4WYWjHKz3cTg1g_hTjNZAv4TAzDjLztv9jwBjEa+jQ@mail.gmail.com>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	<CAJ3xEMiREq3yXerALESc9NNT1YCAjsU6GX+fm5-SRpfB2hTJHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:33325 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbbCZJ4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 05:56:35 -0400
Received: by labto5 with SMTP id to5so41293460lab.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 02:56:33 -0700 (PDT)
In-Reply-To: <CAJ3xEMiREq3yXerALESc9NNT1YCAjsU6GX+fm5-SRpfB2hTJHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 4:17 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Sun, Jan 25, 2015 at 3:51 PM, Amir Vadai <amirv@mellanox.com> wrote:
>> Hi Ben,
>>
>> This patchset contains some features and small bug fixes.
>> A patch by Eyal Perry to enable setting RSS hash function, kernel support was
>> added in commit 892311f ("ethtool: Support for configurable RSS hash
>> function").
>> Eyal Grossman added some missing advertised speeds and fixed some issues in
>> this area of code.
>
> Ben, Amir, where this series stands?
>

Hi Ben,

Is there something you need from us to make it in?

Amir
