From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net] selftests/net: Fixes psock_fanout CBPF test case
Date: Tue, 18 Apr 2017 13:03:02 -0400
Message-ID: <20170418170302.GH18699@oracle.com>
References: <20170418151416.17858-1-maloneykernel@gmail.com>
 <20170418152616.GE18699@oracle.com>
 <CAJegeYmU4ntddE8cHFZT5QM0=aOzu0s1pYkQMehREv56JorEog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        Mike Maloney <maloney@google.com>
To: Mike Maloney <maloneykernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40869 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754847AbdDRRDK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:03:10 -0400
Content-Disposition: inline
In-Reply-To: <CAJegeYmU4ntddE8cHFZT5QM0=aOzu0s1pYkQMehREv56JorEog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (04/18/17 11:56), Mike Maloney wrote:
> I am not 100% sure what you are asking for, as the instructions you
> can feed to bpf_asm are already commented to the right of the program.

oh, right, I missed that you had commented the BPF_STMT macros
with the equivalent bpf_asm inovcation. 

Looks good to me.

--Sowmini
