From: jamal <hadi@cyberus.ca>
Subject: Re: UDP Lite Implementation
Date: 11 Mar 2005 07:36:28 -0500
Message-ID: <1110544588.1089.159.camel@jzny.localdomain>
References: <5.1.0.14.2.20050311133309.00ab5f10@elemail.ele.vtt.fi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Petri Passila <Petri.Passila@vtt.fi>
In-Reply-To: <5.1.0.14.2.20050311133309.00ab5f10@elemail.ele.vtt.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Start looking at udp code and go from there. 
What do you see as an issue that will slow you down?
You should probably be able to cutnpaste a lot of the code from UDP.
Of course forget about other OSes - implement on Linux.

cheers,
jamal

On Fri, 2005-03-11 at 06:34, Petri Passila wrote:
> Hello !
> 
> I am doing my bachelors thesis here in Recearch center of Finland (VTT 
> Electronics) in Oulu. The meaning of the thesis is to compare UDP and UDP 
> Lite using multimedia streaming. The part of my job is to implement UDP 
> Lite into the Linux protocol stack (or FreeBSDs). And I have encountered 
> some difficulties during my way.
> 
> I am investigating the operation of the Linux protocol stack and the udp.c 
> file tells that you are the athors for the UDP. And I am courious to know 
> if you might know something about implementing the UDP Lite. So I wonder if 
> you could possibly help me in my thesis. If you had some information about 
> porting, which could help me, or the whole implementation I would be 
> grateful to hear about it. Or, do you know someone who might know about the 
> issue?
> 
> Our platform is constructed of a FreeBSD 5.1 and Linux RH9 (kernel 2.4.20) 
> machine(s).
> 
> 
> Sincerely yours
> 
> 
> 
> Petri Passila
> VTT Electronics
> Telecommunication Systems
> Wireless Services group
> 
> Work Tel. 040-5425526
> GSM +35840-731 0109
> mail: petri.passila@vtt.fi
> 
> 
> 
> 
