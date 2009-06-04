From: Andrew Grover <andy.grover@gmail.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Wed, 3 Jun 2009 18:44:22 -0700
Message-ID: <c0a09e5c0906031844v7e88572ewdab7b9c4e1295c0c@mail.gmail.com>
References: <20090520230652.GB5956@ghostprotocols.net>
	 <20090522200611.GB967@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f189.google.com ([209.85.221.189]:62964 "EHLO
	mail-qy0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbZFDBt2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 21:49:28 -0400
Received: by qyk27 with SMTP id 27so723530qyk.33
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 18:49:30 -0700 (PDT)
In-Reply-To: <20090522200611.GB967@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2009 at 1:06 PM, Neil Horman <nhorman@tuxdriver.com> wr=
ote:
> Not to throw more questions into the mix again, but didn't Ingo write=
 a
> batching syscall a while back, which let you issue several syscalls i=
n one trap
> to kernel space? =A0I understand that your approach has some efficien=
cy gains over
> that, but did that ever get accepted upstream? =A0Is the overlap ther=
e sufficient
> to make this approach redundant? =A0Or are the gains in performance h=
ere
> sufficient to warrant this new call?

I couldn't find this via Google or any posts to LKML by Ingo on this?

I'm very interested in multiple send/recvmsg support. So, it's
definitely going to happen? :-)

Regards -- Andy
