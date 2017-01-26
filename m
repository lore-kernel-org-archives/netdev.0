From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/3] trace: add variant without spacing in trace_print_hex_seq
Date: Thu, 26 Jan 2017 21:40:55 +0100
Message-ID: <588A5ED7.4060001@iogearbox.net>
References: <cover.1485306168.git.daniel@iogearbox.net> <f860273ed9fd0c423f4d1ee2ab93565992d76ff4.1485306168.git.daniel@iogearbox.net> <20170126195306.GD17504@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170126195306.GD17504@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/26/2017 08:53 PM, Arnaldo Carvalho de Melo wrote:
> Em Wed, Jan 25, 2017 at 02:28:16AM +0100, Daniel Borkmann escreveu:
>> For upcoming tracepoint support for BPF, we want to dump the program's
>> tag. Format should be similar to __print_hex(), but without spacing.
>> Add a __print_hex_str() variant for exactly that purpose that reuses
>> trace_print_hex_seq().
>
> Steven should be back to his side of the wall soon, will wait for his
> Ack, ok?

Ok, seems this set got applied already to net-next in the meantime, so
if there are any objections on this, I will follow up with a patch of
course.

Thanks,
Daniel

> - Arnaldo
