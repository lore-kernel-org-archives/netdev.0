From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH nf-next v8 1/8] netfilter: Remove IP_CT_NEW_REPLY definition.
Date: Thu, 10 Mar 2016 10:44:51 -0800
Message-ID: <B234C951-5BA2-4A1F-B418-FCDDDEEBE544@ovn.org>
References: <1457483084-13944-1-git-send-email-jarno@ovn.org> <CAJ3xEMjEhfGBL9ts-vMMShEzyN+hN2mQL1oYNY2PmFyNw-npsQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:43111 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbcCJSo7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 13:44:59 -0500
In-Reply-To: <CAJ3xEMjEhfGBL9ts-vMMShEzyN+hN2mQL1oYNY2PmFyNw-npsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for pointing this out, v10, which hope is the final version, will have the cover letter back.

  Jarno

> On Mar 10, 2016, at 1:16 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> 
> On Wed, Mar 9, 2016 at 2:24 AM, Jarno Rajahalme <jarno@ovn.org> wrote:
>> Remove the definition of IP_CT_NEW_REPLY from the kernel as it does
>> not make sense.  This allows the definition of IP_CT_NUMBER to be
>> simplified as well.
> 
> I just realized that after V7 you stopped sending cover letter (patch 0/N)
> with this series.
> 
> Maybe you send it and this misses the list? we need to be able to see
> differences from earlier versions.
> 
> Or.
