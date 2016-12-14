From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/3] selftests: do not require bash to run bpf tests
Date: Wed, 14 Dec 2016 12:03:43 +0100
Message-ID: <5851270F.4090709@iogearbox.net>
References: <3057464.DrP1iNtcaF@devpool21>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@kernel.org>,
        linux-kernel@vger.kernel.org, Shuah Khan <shuahkh@osg.samsung.com>,
        Shuah Khan <shuah@kernel.org>
To: Rolf Eike Beer <eb@emlix.com>, linux-kselftest@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3057464.DrP1iNtcaF@devpool21>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/14/2016 11:58 AM, Rolf Eike Beer wrote:
>  From b9d6c1b7427d708ef2d4d57aac17b700b3694d71 Mon Sep 17 00:00:00 2001
> From: Rolf Eike Beer <eike-kernel@sf-tec.de>
> Date: Wed, 14 Dec 2016 09:58:12 +0100
> Subject: [PATCH 2/3] selftests: do not require bash to run bpf tests
>
> Nothing in this minimal script seems to require bash. We often run these tests
> on embedded devices where the only shell available is the busybox ash.
>
> Signed-off-by: Rolf Eike Beer <eb@emlix.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
