From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 21 Apr 2009 22:46:58 +0200
Message-ID: <7e0dd21a0904211346p523b1e1fo7f8ec7bd18ad87cf@mail.gmail.com>
References: <1238701718.5669.26.camel@bender>
	 <alpine.DEB.1.10.0904211131340.21796@qirst.com>
	 <7e0dd21a0904211313p73143cc8t51b5c537c5edfb05@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f163.google.com ([209.85.218.163]:56584 "EHLO
	mail-bw0-f163.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755977AbZDUUrA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 16:47:00 -0400
Received: by bwz7 with SMTP id 7so1979584bwz.37
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 13:46:58 -0700 (PDT)
In-Reply-To: <7e0dd21a0904211313p73143cc8t51b5c537c5edfb05@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>> Could you clean then states up a bit to reflect what they actually m=
ean?
>>
>> TP_STATUS_AVAILABLE =A0 =A0 =A0 =A0 =A0 =A0 =3D> Frame is available
>> TP_STATUS_SEND_REQUEST =A0 =A0 =A0 =A0 =A0=3D> Frame waits for sendi=
ng
>> TP_STATUS_SENDING =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D> Frame is being se=
nt.
>
> Ok

Do you suggest to replace previous TP_STATUS_KERNEL with TP_STATUS_AVAI=
LABLE?
or Add a new status?

Thanks in advance,
Johann
