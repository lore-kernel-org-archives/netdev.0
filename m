From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: Still bug-hunting
Date: Sat, 05 Mar 2005 19:54:49 +0100
Message-ID: <422A0079.4080806@rapidforum.com>
References: <4229F2EC.8090103@rapidforum.com>	<20050305102918.15fd422c.davem@davemloft.net>	<4229FC15.3070408@rapidforum.com> <20050305104854.45106335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050305104854.45106335.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

You as an expert should know that this is no one-liner. It is a very complex server with 
multiplexing and forking like Apache. I dont feel like writing an apache-like program just for 
testing. I hope you understand that I prefered investing my time in acutally searching the bug and 
now its found. Now I hope that you can fix it or at least tell me your ideas.

David S. Miller wrote:
> On Sat, 05 Mar 2005 19:36:05 +0100
> Christian Schmid <webmaster@rapidforum.com> wrote:
> 
> 
>>Sorry? What do you mean?
> 
> 
> I'm being sarcastic in that you didn't provide the test
> case we asked you to provide so we could reproduce the
> many-socket slowdown too and help you figure out what
> was going wrong.
> 
> 
