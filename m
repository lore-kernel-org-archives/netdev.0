From: Clifford Heath <clifford.heath@gmail.com>
Subject: Re: Network hangs with 2.6.30.5
Date: Fri, 11 Sep 2009 08:41:35 +1000
Message-ID: <6529E18B-D422-4D83-95E6-02B6536E3D62@gmail.com>
References: <20090907072143.GA5966@ff.dom.local>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:29300 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753391AbZIKWf7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 18:35:59 -0400
Received: by qw-out-2122.google.com with SMTP id 9so519382qwb.37
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2009 15:36:02 -0700 (PDT)
In-Reply-To: <20090907072143.GA5966@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2009, at 5:21 PM, Jarek Poplawski wrote:
> On 03-09-2009 21:55, Holger Hoffstaette wrote:
>> On Thu, 03 Sep 2009 21:27:08 +0200, Eric Dumazet wrote:
>>> Holger Hoffstaette a =E9crit :
>>>> Problem found! At least for me..
> ...
>> Was that somewhat helpful? I can certainly create a full trace but =20
>> that's
>> going to be big.
>
> Congratulations for finding the culprit!

While it's excellent that Holger has found his problem, the
original problem (posted by me) remains. Unfortunately the
machine affected has had a hard disk meltdown (too many
kernel builds? :-)) and so I can't continue with my testing
before I fix that. Just wanted to note that it's still a live issue.

Clifford Heath.