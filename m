From: Tushar Behera <tushar.behera@linaro.org>
Subject: Re: [PATCH 09/15] net: can: Convert to use devm_ioremap_resource
Date: Tue, 11 Jun 2013 08:45:47 +0530
Message-ID: <51B69663.5080304@linaro.org>
References: <1370864113-17895-1-git-send-email-tushar.behera@linaro.org> <1370864113-17895-10-git-send-email-tushar.behera@linaro.org> <51B5D007.8050005@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, thierry.reding@gmail.com,
	patches@linaro.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
	'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <51B5D007.8050005@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+CC: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>

On 06/10/2013 06:39 PM, Marc Kleine-Budde wrote:
> On 06/10/2013 01:35 PM, Tushar Behera wrote:
>> Commit 75096579c3ac ("lib: devres: Introduce devm_ioremap_resource()")
>> introduced devm_ioremap_resource() and deprecated the use of
>> devm_request_and_ioremap().
> 
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
> 
> Are the patches going over the individual subsystem maintainers?
> 
> Marc
> 

I am not sure. Looping in Greg for clarity.

-- 
Tushar Behera
