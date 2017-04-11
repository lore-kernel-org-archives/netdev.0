From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: Re: [PATCH net-next] bpf: add test_progs to .gitignore
Date: Tue, 11 Apr 2017 16:43:08 +0200
Message-ID: <20170411144308.GA3700@gmail.com>
References: <20170411113538.31423-1-alexander@alemayhu.com>
 <58ECC2B6.1020104@iogearbox.net>
 <20170411121427.GB5207@gmail.com>
 <6cea626b-d95d-743b-2f3e-d64e65d9df88@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        ast@fb.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:33132 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753724AbdDKOnM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:43:12 -0400
Received: by mail-lf0-f46.google.com with SMTP id h125so88111097lfe.0
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 07:43:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <6cea626b-d95d-743b-2f3e-d64e65d9df88@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 11, 2017 at 08:08:24AM -0600, David Ahern wrote:
> 
> listing each program is not a sustainable way to do this. It would be
> simpler to put build targets into a build directory and then ignore the
> build directory.

Agreed. It has probably been raised before, but if no one else does I can send
something later (still learning the make syntax).

Thanks.

-- 
Mit freundlichen Grüßen

Alexander Alemayhu
