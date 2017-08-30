From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH][net-next][V3] bpf: test_maps: fix typos, "conenct" and
 "listeen"
Date: Wed, 30 Aug 2017 22:24:14 +0200
Message-ID: <59A71EEE.3050106@iogearbox.net>
References: <20170830171525.5688-1-colin.king@canonical.com> <59A70831.6080501@iogearbox.net> <9863bea1-5325-edc8-ca46-46e2a738782c@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: shuah@kernel.org, Colin King <colin.king@canonical.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shuah Khan <shuahkh@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9863bea1-5325-edc8-ca46-46e2a738782c@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/30/2017 10:13 PM, Shuah Khan wrote:
> On 08/30/2017 12:47 PM, Daniel Borkmann wrote:
>> On 08/30/2017 07:15 PM, Colin King wrote:
>>> From: Colin Ian King <colin.king@canonical.com>
>>>
>>> Trivial fix to typos in printf error messages:
>>> "conenct" -> "connect"
>>> "listeen" -> "listen"
>>>
>>> thanks to Daniel Borkmann for spotting one of these mistakes
>>>
>>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>>
>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>
> I can get this into 4.14-rc1 unless it should go through net-next
> for dependencies. In which case,

Yeah, it does depends on work sitting in net-next so easier
to go that route.

Thanks,
Daniel
