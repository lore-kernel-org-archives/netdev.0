From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Question about Patch Submissions
Date: Tue, 18 Nov 2014 17:38:58 -0800
Message-ID: <CAADnVQ+1_Ct3hhmZrCqpxcT=-XS4OXrpRbrHHHyOKQOuoDc06g@mail.gmail.com>
References: <546B9A45.9040509@psc.edu>
	<CAHA+R7P-G4P-AzTM248FqNEm=dcuQOB_fwdM0Us3gsQgSeY0UQ@mail.gmail.com>
	<546BAE75.7080802@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <cwang@twopensource.com>, netdev <netdev@vger.kernel.org>
To: rapier <rapier@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:37338 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754004AbaKSBjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 20:39:00 -0500
Received: by mail-qc0-f170.google.com with SMTP id x3so5055505qcv.1
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 17:38:59 -0800 (PST)
In-Reply-To: <546BAE75.7080802@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 12:39 PM, rapier <rapier@psc.edu> wrote:
> break this down for presentation. We can make sure each section of the patch
> applies cleanly but the entirety of the patch set would have to be applied
> for it to compile.

all patches need to compile cleanly on all architectures,
otherwise bisect will be broken.
