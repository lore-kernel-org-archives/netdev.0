From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: ARGH MORE BUGS!!!
Date: Tue, 22 Feb 2005 01:10:46 +0100
Message-ID: <421A7886.8060302@rapidforum.com>
References: <421A3EB8.4050607@rapidforum.com> <20050221202854.GA26248@electric-eye.fr.zoreil.com> <421A45CA.80001@rapidforum.com> <20050221205606.GB26248@electric-eye.fr.zoreil.com> <421A4FFA.7090003@rapidforum.com> <20050221213610.GC26248@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050221213610.GC26248@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I FOUND IT!!!

At least I were able to track this down very far. It seems it only appears on Port 80. So might 
there be a problem if too many sockets are sharing the same port? In this case, port 80?

What can I do now? The problem is still there. All 60 seconds a break for 5 seconds. I am not really 
willing to reboot anymore. So bug-hunters, please help.

Francois Romieu wrote:
> Christian Schmid <webmaster@rapidforum.com> :
> 
>>I started it after one break-cyclus and stopped it immedately after the 
>>next break-cyclus ended.
> 
> 
> I'd welcome several cycles to feed the data through gnuplot.
> A sample based on 15 minutes or more would not hurt: I speak perl too.
> 
> --
> Ueimor
> 
> 
