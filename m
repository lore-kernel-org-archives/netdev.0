From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC] textsearch infrastructure et al v2
Date: Sat, 28 May 2005 14:58:37 +0200
Message-ID: <42986AFD.6060107@eurodev.net>
References: <20050527224725.GG15391@postel.suug.ch> <1117281581.6251.68.camel@localhost.localdomain> <20050528123542.GR15391@postel.suug.ch> <42986A85.9060001@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <42986A85.9060001@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pablo Neira wrote:
>> Same for my infrastructure with the difference that libqsearch uses
>> a single input buffer so no chance for non-linear data.
> 
> 
> hm, i don't understand quite well, i bet that libqsearch was already 
> fragment-aware. Anyway the main difference is that libqsearch wasn't 
> designed to be used in user space so, for example, it needed a complete 
> rework to reduce dynamic memory allocations.

sorry, i meant '/s/wasn't/was/g'. libqsearch was designed to be used my 
snort.

--
Pablo
