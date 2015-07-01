From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] test_bpf: extend tests for 32-bit endianness
 conversion
Date: Tue, 30 Jun 2015 20:03:07 -0700
Message-ID: <5593586B.5080703@plumgrid.com>
References: <1435332320-6476-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33245 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbbGADDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 23:03:10 -0400
Received: by pacws9 with SMTP id ws9so15492850pac.0
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2015 20:03:09 -0700 (PDT)
In-Reply-To: <1435332320-6476-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/26/15 8:25 AM, Xi Wang wrote:
> Currently "ALU_END_FROM_BE 32" and "ALU_END_FROM_LE 32" do not test if
> the upper bits of the result are zeros (the arm64 JIT had such bugs).
> Extend the two tests to catch this.
>
> Cc: Alexei Starovoitov<ast@plumgrid.com>
> Signed-off-by: Xi Wang<xi.wang@gmail.com>

looks good. Please resubmit when net-next reopens. Thanks!
