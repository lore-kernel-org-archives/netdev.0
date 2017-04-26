From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: Re: [PATCH net-next 3/3] samples/bpf: check before defining offsetof
Date: Wed, 26 Apr 2017 07:17:04 +0200
Message-ID: <20170426051704.GA13467@gmail.com>
References: <20170424133108.31595-1-alexander@alemayhu.com>
 <20170424133108.31595-4-alexander@alemayhu.com>
 <58FE0E96.9020403@iogearbox.net>
 <063D6719AE5E284EB5DD2968C1650D6DCFFDAD25@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: 'Daniel Borkmann' <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "ast@fb.com" <ast@fb.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:34427 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1043708AbdDZFRI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 01:17:08 -0400
Received: by mail-lf0-f41.google.com with SMTP id t144so101636694lff.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 22:17:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFDAD25@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 02:27:16PM +0000, David Laight wrote:
> 
> Isn't the correct fix to include stddef.h ?
>
If you think it's the correct fix, please send a patch to netdev.

Thanks.

-- 
Mit freundlichen Grüßen

Alexander Alemayhu
