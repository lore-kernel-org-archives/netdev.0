From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH] tests: Remove bashisms (s/source/.)
Date: Wed, 11 Oct 2017 11:02:49 -0700
Message-ID: <290f2f69-48ee-f47f-2704-293b5354baed@infradead.org>
References: <20171008143916.21813-1-petr.vorel@gmail.com>
 <20171011110115.13739488@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
        Petr Vorel <petr.vorel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:52214 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757505AbdJKSCu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 14:02:50 -0400
In-Reply-To: <20171011110115.13739488@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/17 11:01, Stephen Hemminger wrote:
> On Sun,  8 Oct 2017 16:39:16 +0200
> Petr Vorel <petr.vorel@gmail.com> wrote:
> 
>> Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
> 
> Ok, applied. But iproute2 is really limited to Linux and bash is lingua franca on Linux
> 

no French, please. Some distros use dash, but being POSIX is usually good.

-- 
~Randy
