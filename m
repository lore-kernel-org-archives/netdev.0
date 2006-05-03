From: Pekka J Enberg <penberg@cs.Helsinki.FI>
Subject: Re: [PATCH] ipg: removing more dead code
Date: Wed, 3 May 2006 16:12:31 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0605031610280.19727@sbz-30.cs.Helsinki.FI>
References: <20060429122119.GA22160@fargo> <1146342905.11271.3.camel@localhost>
 <1146389171.11524.1.camel@localhost> <44554ADE.8030200@cantab.net>
 <4455F1D8.5030102@cantab.net> <1146506939.23931.2.camel@localhost>
 <20060501231050.GC7419@electric-eye.fr.zoreil.com>
 <Pine.LNX.4.58.0605020936420.4066@sbz-30.cs.Helsinki.FI>
 <20060502183313.GA26357@electric-eye.fr.zoreil.com> <1146596687.13675.1.camel@localhost>
 <20060502223048.GA32038@fargo>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Vrabel <dvrabel@cantab.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:10661 "EHLO
	mail.cs.helsinki.fi") by vger.kernel.org with ESMTP id S965081AbWECNMd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 09:12:33 -0400
To: "David =?utf-8?B?R8OzbWV6?=" <david@pleyades.net>
In-Reply-To: <20060502223048.GA32038@fargo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Wed, 3 May 2006, David G=F3mezz wrote:
> I'll test it tomorrow ASAP. For now, here is another patch removing
> more dead code. This code is never reached (NOTGRACE is not defined)
> and the *fiber_detect functions are subsequently never used.

No need to resend this one, but in future, please follow the proper pat=
ch=20
format:

  http://www.zipworld.com.au/~akpm/linux/patches/stuff/tpp.txt

			Pekka
