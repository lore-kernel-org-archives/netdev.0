From: "Laurent Chavey" <chavey@google.com>
Subject: Re: autotest question
Date: Mon, 15 Sep 2008 14:38:13 -0700
Message-ID: <97949e3e0809151438w17e68c50pdc4cba68dc4ec7b1@mail.gmail.com>
References: <97949e3e0809151337r4dc69f8cydd92074bb10088d8@mail.gmail.com>
	 <Pine.LNX.4.64.0809151433001.7365@shark.he.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Mandeep Singh Baines" <msb@google.com>, netdev@vger.kernel.org
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:36333 "EHLO
	smtp-out3.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753404AbYIOViU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 17:38:20 -0400
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out3.google.com with ESMTP id m8FLcE1s020019
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 22:38:14 +0100
Received: from rv-out-0506.google.com (rvbg37.prod.google.com [10.140.83.37])
	by spaceape10.eur.corp.google.com with ESMTP id m8FLbk5c016492
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 14:38:14 -0700
Received: by rv-out-0506.google.com with SMTP id g37so2215429rvb.35
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 14:38:13 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0809151433001.7365@shark.he.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sorry, typed (spammed) the wrong mailing list.


On Mon, Sep 15, 2008 at 2:33 PM, Randy.Dunlap <rdunlap@xenotime.net> wrote:
> On Mon, 15 Sep 2008, Laurent Chavey wrote:
>
>> how many control file can we have per sub directories.
>> I would like to have a glag_test/ directory with multiple testes (lldp
>> test, af_pkt)
>> each tests are independent of each other and use to verify a CL.
>>
>>
>>
>> example:
>>   /depot/autotest/client/site_tests/glag_tests
>>     control
>>     glag_lldp_test.py
>>     glag_afpacket_test.py
>>     glag_linkup_test.py
>>
>>     etc...
>> --
>
> Does the netdev mailing list care about this question?
> I.e., seems like the wrong mailing list to me.
>
> --
> ~Randy
>
